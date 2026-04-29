import logging

import ckan.plugins as p
from ckan.common import g

log = logging.getLogger(__name__)


class SfbDraftSearchPlugin(p.SingletonPlugin):
    p.implements(p.IPackageController, inherit=True)

    def before_dataset_search(self, search_params):
        params = dict(search_params or {})

        try:
            userobj = getattr(g, "userobj", None)
        except RuntimeError:
            userobj = None

        if userobj and getattr(userobj, "sysadmin", False):
            params["include_drafts"] = True
            log.debug("sfb_drafts_search: include_drafts=True aplicado para sysadmin")

        return params
