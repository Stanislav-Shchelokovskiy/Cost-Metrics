from typing import Any
from collections.abc import Sequence, Callable
from toolbox.sql.meta_data import MetaData, KnotMeta
from toolbox.sql.field import Field, TEXT
import toolbox.sql.generators.sqlite.statements as sqlite_index


class Teams(MetaData):
    name = Field(TEXT)


class Tribes(KnotMeta):
    pass


class Tents(KnotMeta):
    pass


class Positions(KnotMeta):
    pass


class Employees(MetaData):
    crmid = Field(TEXT)
    scid = Field(TEXT)
    name = Field(TEXT)
    team = Field(TEXT)
    tribe_id = Field(TEXT)
    tent_id = Field(TEXT)
    position_id = Field(TEXT)

    @classmethod
    def get_key_fields(
        cls,
        projector: Callable[[Field], Any] = str,
        *exfields: Field,
    ) -> Sequence[Field | str | Any]:
        return tuple()

    @classmethod
    def get_indices(cls) -> Sequence[str]:
        return (
            sqlite_index.create_index(
                tbl=cls.get_name(),
                cols=(
                    cls.team,
                    cls.tribe_id,
                    cls.tent_id,
                    cls.position_id,
                    cls.name,
                    cls.scid,
                ),
            ),
        )


class Employee(MetaData):
    scid = Employees.scid
    name = Employees.name

    @classmethod
    def get_name(cls) -> str:
        return Employees.get_name()
