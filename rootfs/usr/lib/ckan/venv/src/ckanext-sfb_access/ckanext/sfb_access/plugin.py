import ckan.model as model
from sqlalchemy import text
import ckan.plugins as p
import ckan.plugins.toolkit as tk
from ckan.lib.plugins import DefaultPermissionLabels

ACCESS_FIELD_NAME = "sfb_acesso"
PORTAL_FECHADO = True
INTERNAL_USERNAMES = ""

DEBUG_LOG = "/tmp/sfb_access_debug.log"

def _dbg(msg):
    try:
        with open(DEBUG_LOG, "a", encoding="utf-8") as f:
            f.write(str(msg) + "\n")
    except Exception:
        pass


def _split_csv(value):
    if not value:
        return []
    return [x.strip() for x in str(value).split(",") if x.strip()]

def _obj_extra(obj, key):
    if not obj or not key:
        return None

    pkg_id = getattr(obj, "id", None)
    if pkg_id:
        try:
            row = model.Session.execute(
                text("SELECT value FROM package_extra WHERE package_id = :pkg_id AND key = :key LIMIT 1"),
                {"pkg_id": pkg_id, "key": key},
            ).fetchone()
            if row is not None:
                return row[0]
        except Exception:
            pass

    extras = getattr(obj, "extras", None) or []
    try:
        if isinstance(extras, dict):
            return extras.get(key)
    except Exception:
        pass

    for e in extras:
        try:
            if getattr(e, "key", None) == key:
                return getattr(e, "value", None)
        except Exception:
            pass

    return None

def _dd(data_dict, key):
    value = data_dict.get(key)
    if value not in (None, ""):
        return value
    for e in data_dict.get("extras", []) or []:
        if e.get("key") == key:
            return e.get("value")
    return None

def _normalize_access(raw):
    value = str(raw or "PUBLICO").strip().upper()
    mapping = {
        "PUBLICO": "PUBLICO",
        "PÚBLICO": "PUBLICO",
        "PUBLIC": "PUBLICO",
        "INTERNO": "INTERNO",
        "INTERNO SFB": "INTERNO",
        "INTERNO_SFB": "INTERNO",
        "PRIVADO": "PRIVADO",
        "PRIVATE": "PRIVADO",
        "RESTRITO_PROJETO": "PRIVADO",
        "EM_VALIDACAO": "PRIVADO",
        "EM VALIDAÇÃO": "PRIVADO",
        "HISTORICO_OBSOLETO": "PRIVADO",
    }
    return mapping.get(value, "PUBLICO")

def _dataset_access(pkg):
    return _normalize_access(_obj_extra(pkg, ACCESS_FIELD_NAME))

def _data_dict_access(data_dict):
    return _normalize_access(_dd(data_dict, ACCESS_FIELD_NAME))

def _enforce_private(data_dict):
    mode = _data_dict_access(data_dict)
    data_dict["private"] = (mode == "PRIVADO")

def _user_obj_from_context(context):
    user_obj = context.get("auth_user_obj")
    if user_obj:
        return user_obj

    user_ref = context.get("user")
    if not user_ref:
        return None

    try:
        return model.User.get(user_ref)
    except Exception:
        return None

def _is_sysadmin(user_obj):
    return bool(user_obj and getattr(user_obj, "sysadmin", False))

def _is_owner(user_obj, pkg):
    if not user_obj or not pkg:
        return False

    uid = str(getattr(user_obj, "id", "") or "")
    uname = str(getattr(user_obj, "name", "") or "")
    creator_user_id = str(getattr(pkg, "creator_user_id", "") or "")
    creator = str(getattr(pkg, "creator", "") or "")

    if uid and creator_user_id and uid == creator_user_id:
        return True
    if uname and creator and uname == creator:
        return True

    return False

def _is_internal(user_obj):
    if not user_obj:
        return False

    if getattr(user_obj, "is_anonymous", False):
        return False

    uname = str(getattr(user_obj, "name", "") or "").strip()
    if not uname or uname.lower() in {"visitor", "default"}:
        return False

    if _is_sysadmin(user_obj):
        return True

    if PORTAL_FECHADO:
        return True

    allowed = {x.strip().lower() for x in _split_csv(INTERNAL_USERNAMES)}
    return uname.lower() in allowed

def _pkg_from_data_dict(data_dict):
    pkg_ref = data_dict.get("id") or data_dict.get("name") or data_dict.get("package_id")
    if not pkg_ref:
        return None

    try:
        pkg = model.Package.get(pkg_ref)
        if pkg:
            return pkg
    except Exception:
        pass

    try:
        return (
            model.Session.query(model.Package)
            .filter(model.Package.name == str(pkg_ref))
            .filter(model.Package.state == "active")
            .first()
        )
    except Exception:
        return None

def _pkg_from_resource_data_dict(data_dict):
    package_id = data_dict.get("package_id")
    if package_id:
        try:
            return model.Package.get(package_id)
        except Exception:
            pass

    resource_id = data_dict.get("id")
    if resource_id:
        try:
            resource = model.Resource.get(resource_id)
            if resource and getattr(resource, "package_id", None):
                return model.Package.get(resource.package_id)
        except Exception:
            pass

    return None

def _owner_labels_for_pkg(pkg):
    labels = []
    creator_user_id = str(getattr(pkg, "creator_user_id", "") or "")
    creator = str(getattr(pkg, "creator", "") or "")
    if creator_user_id:
        labels.append(f"sfb:owner_id:{creator_user_id}")
    if creator:
        labels.append(f"sfb:owner_name:{creator}")
    return labels

def _owner_labels_for_user(user_obj):
    labels = []
    if not user_obj:
        return labels
    uid = str(getattr(user_obj, "id", "") or "")
    uname = str(getattr(user_obj, "name", "") or "")
    if uid:
        labels.append(f"sfb:owner_id:{uid}")
    if uname:
        labels.append(f"sfb:owner_name:{uname}")
    return labels

def _can_read(context, pkg):
    mode = _dataset_access(pkg)
    user_obj = _user_obj_from_context(context)

    if mode == "PUBLICO":
        return True

    if mode == "INTERNO":
        return _is_internal(user_obj)

    if mode == "PRIVADO":
        return _is_sysadmin(user_obj) or _is_owner(user_obj, pkg)

    return True

@tk.chained_action
def package_create(orig, context, data_dict):
    _enforce_private(data_dict)
    return orig(context, data_dict)

@tk.chained_action
def package_update(orig, context, data_dict):
    _enforce_private(data_dict)
    return orig(context, data_dict)

@tk.chained_action
def package_patch(orig, context, data_dict):
    _enforce_private(data_dict)
    return orig(context, data_dict)

class SfbAccess(p.SingletonPlugin, DefaultPermissionLabels):
    p.implements(p.IActions)
    p.implements(p.IAuthFunctions, inherit=True)
    p.implements(p.IPermissionLabels, inherit=True)
    p.implements(p.ITemplateHelpers)

    def get_actions(self):
        return {
            "package_create": package_create,
            "package_update": package_update,
            "package_patch": package_patch,
        }

    def get_auth_functions(self):

        @tk.auth_allow_anonymous_access
        @tk.chained_auth_function
        def package_show(next_auth, context, data_dict):
            _dbg(f"PACKAGE_SHOW_START user={context.get('user')!r} auth_user_obj={getattr(context.get('auth_user_obj'), 'name', None)!r} data_dict={data_dict!r}")
            result = next_auth(context, data_dict)
            _dbg(f"PACKAGE_SHOW_NEXT_AUTH success={result.get('success')!r} result={result!r}")
            if not result.get("success"):
                return result

            pkg = _pkg_from_data_dict(data_dict)
            _dbg(f"PACKAGE_SHOW_PKG resolved={getattr(pkg, 'name', None)!r} id={getattr(pkg, 'id', None)!r} access={_dataset_access(pkg) if pkg else None!r}")
            if not pkg:
                return result

            allow = _can_read(context, pkg)
            _dbg(f"PACKAGE_SHOW_CAN_READ allow={allow!r} context_user={context.get('user')!r} pkg={getattr(pkg, 'name', None)!r}")
            if allow:
                return result

            return {"success": False, "msg": "Sem permissão para visualizar este registro."}

        @tk.auth_allow_anonymous_access
        @tk.chained_auth_function
        def resource_show(next_auth, context, data_dict):
            result = next_auth(context, data_dict)
            if not result.get("success"):
                return result

            pkg = _pkg_from_resource_data_dict(data_dict)
            if not pkg:
                return result

            if _can_read(context, pkg):
                return result

            return {"success": False, "msg": "Sem permissão para visualizar este recurso."}

        @tk.chained_auth_function
        def package_update(next_auth, context, data_dict):
            result = next_auth(context, data_dict)
            if not result.get("success"):
                return result

            pkg = _pkg_from_data_dict(data_dict)
            if not pkg:
                return result

            if _dataset_access(pkg) != "PRIVADO":
                return result

            user_obj = _user_obj_from_context(context)
            if _is_sysadmin(user_obj) or _is_owner(user_obj, pkg):
                return result

            return {"success": False, "msg": "Dataset PRIVADO: apenas owner ou sysadmin pode editar."}

        @tk.chained_auth_function
        def package_patch(next_auth, context, data_dict):
            result = next_auth(context, data_dict)
            if not result.get("success"):
                return result

            pkg = _pkg_from_data_dict(data_dict)
            if not pkg:
                return result

            if _dataset_access(pkg) != "PRIVADO":
                return result

            user_obj = _user_obj_from_context(context)
            if _is_sysadmin(user_obj) or _is_owner(user_obj, pkg):
                return result

            return {"success": False, "msg": "Dataset PRIVADO: apenas owner ou sysadmin pode editar."}

        @tk.chained_auth_function
        def package_delete(next_auth, context, data_dict):
            result = next_auth(context, data_dict)
            if not result.get("success"):
                return result

            pkg = _pkg_from_data_dict(data_dict)
            if not pkg:
                return result

            if _dataset_access(pkg) != "PRIVADO":
                return result

            user_obj = _user_obj_from_context(context)
            if _is_sysadmin(user_obj) or _is_owner(user_obj, pkg):
                return result

            return {"success": False, "msg": "Dataset PRIVADO: apenas owner ou sysadmin pode excluir."}

        @tk.chained_auth_function
        def resource_update(next_auth, context, data_dict):
            result = next_auth(context, data_dict)
            if not result.get("success"):
                return result

            pkg = _pkg_from_resource_data_dict(data_dict)
            if not pkg:
                return result

            if _dataset_access(pkg) != "PRIVADO":
                return result

            user_obj = _user_obj_from_context(context)
            if _is_sysadmin(user_obj) or _is_owner(user_obj, pkg):
                return result

            return {"success": False, "msg": "Recurso de dataset PRIVADO: apenas owner ou sysadmin pode editar."}

        @tk.chained_auth_function
        def resource_delete(next_auth, context, data_dict):
            result = next_auth(context, data_dict)
            if not result.get("success"):
                return result

            pkg = _pkg_from_resource_data_dict(data_dict)
            if not pkg:
                return result

            if _dataset_access(pkg) != "PRIVADO":
                return result

            user_obj = _user_obj_from_context(context)
            if _is_sysadmin(user_obj) or _is_owner(user_obj, pkg):
                return result

            return {"success": False, "msg": "Recurso de dataset PRIVADO: apenas owner ou sysadmin pode excluir."}

        return {
            "package_show": package_show,
            "resource_show": resource_show,
            "package_update": package_update,
            "package_patch": package_patch,
            "package_delete": package_delete,
            "resource_update": resource_update,
            "resource_delete": resource_delete,
        }

    def get_dataset_labels(self, pkg):
        mode = _dataset_access(pkg)

        if mode == "PUBLICO":
            return list(dict.fromkeys(super().get_dataset_labels(pkg) + ["sysadmin"]))

        if mode == "INTERNO":
            return ["sfb:interno", "sysadmin"]

        if mode == "PRIVADO":
            return list(dict.fromkeys(["sysadmin"] + _owner_labels_for_pkg(pkg)))

        return list(dict.fromkeys(super().get_dataset_labels(pkg) + ["sysadmin"]))

    def get_user_dataset_labels(self, user_obj):
        labels = list(super().get_user_dataset_labels(user_obj))

        if not user_obj or getattr(user_obj, "is_anonymous", False):
            return list(dict.fromkeys(labels))

        if _is_internal(user_obj):
            labels.append("sfb:interno")

        if _is_sysadmin(user_obj):
            labels.append("sysadmin")

        labels.extend(_owner_labels_for_user(user_obj))
        return list(dict.fromkeys(labels))

    def get_helpers(self):
        return {
            "sfb_access_mode": self._helper_access_mode,
        }

    def _helper_access_mode(self, obj):
        if not obj:
            return "PUBLICO"

        if isinstance(obj, dict):
            return _normalize_access(_dd(obj, ACCESS_FIELD_NAME))

        return _dataset_access(obj)
