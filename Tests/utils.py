import os
import filecmp
from fastapi.testclient import TestClient
from httpx import Response
from pathlib import Path
from Tests.env import with_env


@with_env
def network_post(client: TestClient, url: str, body: str) -> str:
    print(url)
    res: Response = client.post(
        url=url,
        json=body,
        headers={'content-type': 'application/json'},
    )
    return res.text


def response_is_valid(file, check_file, response):
    tmp = Path(f'Tests/{file}')
    tmp.write_text(response)
    target = f'Tests/responses/{check_file}'
    files_content_is_the_same = filecmp.cmp(str(tmp), target)
    tmp.unlink()
    return files_content_is_the_same
