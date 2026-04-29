import ckan.model as model
import ckan.plugins as p
from ckan.lib.plugins import DefaultPermissionLabels

toolkit = p.toolkit

class _DefaultLabels(DefaultPermissionLabels):
    pass

_DEFAULT_LABELS = _DefaultLabels()

def _normalize_bool(value):
    return str(value).strip().lower() in ("1", "true", "yes", "y", "sim")

def _split_csv(value):
    if not value:
        return []
    return [x.strip() for x in str(value).split(",") if x.strip()]

def _dataset_extras_dict(dataset_obj):
    extras = getattr(dataset_obj, "extras_list", None)
    result = {}
    if extras:
        for extra in extras:
            key = getattr(extra, "key", None)
            val = getattr(extra, "value", None)
            if key:
                result[key] = val
    return result

def _dataset_access_value(dataset_obj, access_field_name):
    extras = _dataset_extras_dict(dataset_obj)
    raw = (extras.get(access_field_name) or "").strip().lower()
    return raw or "publico"

def _dataset_group_value(dataset_obj, group_field_name):
    extras = _dataset_extras_dict(dataset_obj)
    raw = (extras.get(group_field_name) or "").strip().lower()
    return raw

def _is_sysadmin(user_obj):
    try:
        return bool(user_obj and getattr(user_obj, "sysadmin", False))
    except Exception:
        return False

def _is_owner(user_obj, dataset_obj):
    if not user_obj or not dataset_obj:
        return False

    user_id = str(getattr(user_obj, "id", "") or "")
    creator_user_id = str(getattr(dataset_obj, "creator_user_id", "") or "")
    if user_id and creator_user_id and user_id == creator_user_id:
        return True

    creator = str(getattr(dataset_obj, "creator", "") or "")
    user_name = str(getattr(user_obj, "name", "") or "")
    if creator and user_name and creator == user_name:
        return True

    return False

def _user_group_names(user_obj):
    names = set()
    if not user_obj:
        return names

    try:
        for group in getattr(user_obj, "groups", []) or []:
            name = getattr(group, "name", None)
            if name:
                names.add(str(name).strip().lower())
    except Exception:
        pass

    try:
        for group in user_obj.get_groups():
            name = getattr(group, "name", None)
            if name:
                names.add(str(name).strip().lower())
    except Exception:
        pass

    return names

def _is_internal(user_obj, portal_fechado, internal_usernames):
    if not user_obj:
        return False

    if _is_sysadmin(user_obj):
        return True

    if _normalize_bool(portal_fechado):
        return True

    allowed = set(_split_csv(internal_usernames))
    username = str(getattr(user_obj, "name", "") or "").strip()
    return bool(username and username in allowed)

def _get_package_from_data_dict(data_dict):
    if not data_dict:
        return None

    pkg_id = data_dict.get("id") or data_dict.get("name") or data_dict.get("package_id")
    if not pkg_id:
        return None

    try:
        return model.Package.get(pkg_id)
    except Exception:
        return None

def _get_package_from_resource_data_dict(data_dict):
    if not data_dict:
        return None

    if data_dict.get("package_id"):
        try:
            return model.Package.get(data_dict["package_id"])
        except Exception:
            pass

    resource_id = data_dict.get("id")
    if not resource_id:
        return None

    try:
        resource = model.Resource.get(resource_id)
        if resource and getattr(resource, "package_id", None):
            return model.Package.get(resource.package_id)
    except Exception:
        return None

    return None

def _private_owner_gate(user_obj, dataset_obj, access_field_name):
    if not dataset_obj:
        return True

    mode = _dataset_access_value(dataset_obj, access_field_name)
    if mode != "privado":
        return True

    if _is_sysadmin(user_obj):
        return True

    if _is_owner(user_obj, dataset_obj):
        return True

    return False

def _build_auth_functions(access_field_name):
    @toolkit.chained_auth_function
    def package_update(next_auth, context, data_dict):
        result = next_auth(context, data_dict)
        if not result.get("success"):
            return result
        user_obj = context.get("auth_user_obj")
        dataset_obj = _get_package_from_data_dict(data_dict)
        if not _private_owner_gate(user_obj, dataset_obj, access_field_name):
            return {"success": False, "msg": "Dataset privado: apenas owner ou sysadmin pode alterar."}
        return result

    @toolkit.chained_auth_function
    def package_patch(next_auth, context, data_dict):
        result = next_auth(context, data_dict)
        if not result.get("success"):
            return result
        user_obj = context.get("auth_user_obj")
        dataset_obj = _get_package_from_data_dict(data_dict)
        if not _private_owner_gate(user_obj, dataset_obj, access_field_name):
            return {"success": False, "msg": "Dataset privado: apenas owner ou sysadmin pode alterar."}
        return result

    @toolkit.chained_auth_function
    def package_delete(next_auth, context, data_dict):
        result = next_auth(context, data_dict)
        if not result.get("success"):
            return result
        user_obj = context.get("auth_user_obj")
        dataset_obj = _get_package_from_data_dict(data_dict)
        if not _private_owner_gate(user_obj, dataset_obj, access_field_name):
            return {"success": False, "msg": "Dataset privado: apenas owner ou sysadmin pode excluir."}
        return result

    @toolkit.chained_auth_function
    def resource_update(next_auth, context, data_dict):
        result = next_auth(context, data_dict)
        if not result.get("success"):
            return result
        user_obj = context.get("auth_user_obj")
        dataset_obj = _get_package_from_resource_data_dict(data_dict)
        if not _private_owner_gate(user_obj, dataset_obj, access_field_name):
            return {"success": False, "msg": "Recurso de dataset privado: apenas owner ou sysadmin pode alterar."}
        return result

    @toolkit.chained_auth_function
    def resource_delete(next_auth, context, data_dict):
        result = next_auth(context, data_dict)
        if not result.get("success"):
            return result
        user_obj = context.get("auth_user_obj")
        dataset_obj = _get_package_from_resource_data_dict(data_dict)
        if not _private_owner_gate(user_obj, dataset_obj, access_field_name):
            return {"success": False, "msg": "Recurso de dataset privado: apenas owner ou sysadmin pode excluir."}
        return result

    return {
        "package_update": package_update,
        "package_patch": package_patch,
        "package_delete": package_delete,
        "resource_update": resource_update,
        "resource_delete": resource_delete,
    }

def patch_plugin_class(plugin_cls,
                       access_field_name="sfb_acesso",
                       portal_fechado=True,
                       internal_usernames="",
                       enable_group_especifico=False,
                       group_field_name="sfb_grupo"):

    enable_group_especifico = _normalize_bool(enable_group_especifico)

    def get_auth_functions(self):
        return _build_auth_functions(access_field_name)

    def get_dataset_labels(self, dataset_obj):
        labels = set(_DEFAULT_LABELS.get_dataset_labels(dataset_obj))
        mode = _dataset_access_value(dataset_obj, access_field_name)

        if mode == "interno":
            labels.discard("public")
            labels.add("sfb:interno")

        elif mode == "privado":
            labels.discard("public")
            creator_user_id = str(getattr(dataset_obj, "creator_user_id", "") or "")
            creator = str(getattr(dataset_obj, "creator", "") or "")
            if creator_user_id:
                labels.add(f"sfb:owner_id:{creator_user_id}")
            if creator:
                labels.add(f"sfb:owner_name:{creator}")

        elif mode == "grupo_especifico" and enable_group_especifico:
            labels.discard("public")
            group_value = _dataset_group_value(dataset_obj, group_field_name)
            if group_value:
                labels.add(f"sfb:grupo:{group_value}")

        return list(labels)

    def get_user_dataset_labels(self, user_obj):
        labels = set(_DEFAULT_LABELS.get_user_dataset_labels(user_obj))

        if _is_internal(user_obj, portal_fechado, internal_usernames):
            labels.add("sfb:interno")

        if user_obj:
            user_id = str(getattr(user_obj, "id", "") or "")
            user_name = str(getattr(user_obj, "name", "") or "")
            if user_id:
                labels.add(f"sfb:owner_id:{user_id}")
            if user_name:
                labels.add(f"sfb:owner_name:{user_name}")

        if enable_group_especifico:
            for group_name in _user_group_names(user_obj):
                labels.add(f"sfb:grupo:{group_name}")

        return list(labels)

    plugin_cls.get_auth_functions = get_auth_functions
    plugin_cls.get_dataset_labels = get_dataset_labels
    plugin_cls.get_user_dataset_labels = get_user_dataset_labels
