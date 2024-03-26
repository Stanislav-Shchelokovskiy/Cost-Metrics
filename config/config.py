import os
from collections.abc import Iterable
from toolbox.utils.converters import JSON_to_object


def __cmp(s1: str, s2: str) -> bool:
    return s1.casefold() == s2.casefold()


def __cmp_role(got: str, want: str) -> bool:
    if got:
        return __cmp(got, want)
    return False


def admin_role() -> str:
    return os.environ['ADMIN_ROLE']


def is_admin(role: str | None) -> bool:
    return __cmp_role(role, admin_role())


def advanced_role() -> str:
    return os.environ['ADVANCED_ROLE']


def is_advanced(role: str | None) -> bool:
    return __cmp_role(role, advanced_role())


def cors_origins() -> Iterable[str]:
    return JSON_to_object.convert(os.environ['CORS_ORIGINS'])
