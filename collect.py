import os
import json
import re
import zipfile
import urllib.request
import requests
from pathlib import Path
from bs4 import BeautifulSoup


def download_script_package(id, dest):
    url = f'https://www.purezc.net/index.php?page=download&section=Scripts&id={id}'
    zip_dest, http_response = urllib.request.urlretrieve(url)
    if http_response.get_content_type() != 'application/zip':
        return None

    zip = zipfile.ZipFile(zip_dest)
    namelist = zip.namelist()
    zip.extractall(dest)
    zip.close()
    os.unlink(zip_dest)
    return namelist


def download_script(id):
    r = requests.get(f'https://www.purezc.net/index.php?page=scripts&id={id}')
    if r.status_code != 200:
        return False

    soup = BeautifulSoup(r.content, 'html.parser')

    name = soup.select_one('.maintitle').text.strip()
    info = soup.select_one('.entryInfo').text.strip()
    description = soup.select_one('#item_content0').text.strip()
    setup = soup.select_one('#item_content1').text.strip()

    overview_spans = [r.text.strip()
                      for r in soup.select('.ipsBox_container .table_row span')]

    def get_overview_value(label):
        for span in overview_spans:
            m = re.search(rf'{label}:(.*)', span,
                          flags=re.MULTILINE | re.DOTALL)
            if m:
                return m.groups()[0].strip()

    author = get_overview_value('Creator')
    added = get_overview_value('Added')
    updated = get_overview_value('Updated')
    tags = get_overview_value('Tags')
    if tags:
        tags = ['#' + t.strip() for t in tags.split(', ')]
    downloads = get_overview_value('Downloads')

    rating = None
    rating_el = soup.select_one('a[data-num-ratings]')
    if rating_el:
        rating = rating_el['data-num-ratings']

    links = soup.select('.ipsBox_container .table_row td a')
    has_zip = any(l for l in links if 'page=download' in l['href'])
    has_popup = any(l for l in links if 'popup=y' in l['href'])

    meta = {
        'name': name,
        'author': author,
        'added': added,
        'updated': updated,
        'tags': tags,
        'rating': rating,
        'downloads': downloads,
        'info': info,
        'description': description,
        'setup': setup,
        'has_zip': has_zip,
        'has_popup': has_popup,
    }

    clean_name = re.sub(r'[^a-z]+', '-', name.lower())
    if clean_name.endswith('-'):
        clean_name = clean_name[0:-1]
    slug = f'{id}-{clean_name}'
    dest = Path(f'tmp/{slug}')
    meta_path = dest / 'meta.json'
    dest.mkdir(exist_ok=True, parents=True)

    images = soup.select('#imagelist2 img')
    image_srcs = [img['src'] for img in images if 'youtube' not in img['src']]
    for image_src in image_srcs:
        urllib.request.urlretrieve(
            f'https://www.purezc.net/{image_src}', dest / Path(image_src).name)

    zipped_files = None
    if has_zip:
        zipped_files = download_script_package(id, dest)

    if has_popup:
        r = requests.get(
            f'https://www.purezc.net/index.php?page=scripts&id={id}&popup=y')
        if r.status_code != 200:
            raise Exception('errored')

        soup = BeautifulSoup(r.content, 'html.parser')
        script = soup.find('pre').text.strip()
        if not script:
            raise Exception('could not find script')

        script_dest = dest / 'script.zs'
        if has_zip and script_dest.name in zipped_files:
            script_dest.name = 'script-popup.zs'
        script_dest.write_text(script, 'utf-8')

    meta_path.write_text(json.dumps(meta, indent=2))
    return True


for i in range(1, 546):
    print(i)
    download_script(i)
