import argparse
import requests

def get_asset_group_id(api_url, api_key, group_name):
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
    }

    response = requests.get(f'{api_url}/api/v1/assets/groups/', headers=headers)

    if response.status_code == 200:
        groups = response.json().get('results', [])
        for group in groups:
            if group['name'] == group_name:
                return group['id']
        else:
            print(f"Asset group '{group_name}' not found.")
    else:
        print(f"Failed to retrieve asset groups. Status code: {response.status_code}")

    return None

def add_ip_to_asset_group(api_url, api_key, asset_group_id, ip):
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
    }

    data = {
        'asset_id': None,
        'asset_group_id': asset_group_id,
        'ip': ip,
    }

    response = requests.post(f'{api_url}/api/v1/assets/assets/', headers=headers, json=data)

    if response.status_code == 201:
        print(f"IP '{ip}' added to asset group successfully.")
    else:
        print(f"Failed to add IP '{ip}' to asset group. Status code: {response.status_code}")

def delete_ip_from_asset(api_url, api_key, asset_id):
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
    }

    response = requests.delete(f'{api_url}/api/v1/assets/assets/{asset_id}/', headers=headers)

    if response.status_code == 204:
        print(f"Asset deleted successfully.")
    else:
        print(f"Failed to delete asset. Status code: {response.status_code}")

def main():
    parser = argparse.ArgumentParser(description='Insert or delete IP from JumpServer asset group.')
    parser.add_argument('--jumpserver-url', default='http://43.132.253.229', help='JumpServer URL')
    parser.add_argument('--api-key', required=True, help='JumpServer API key')
    parser.add_argument('--target-ip', help='IP to be added or deleted')
    parser.add_argument('--asset-group-name', default='/Default/auto-add-test', help='Asset group name')
    parser.add_argument('--add', action='store_true', help='Add the specified IP to asset group')
    parser.add_argument('--delete', action='store_true', help='Delete the specified IP from asset')

    args = parser.parse_args()

    if args.delete and (args.target_ip is None or args.asset_group_name is None):
        parser.error("--target-ip and --asset-group-name are required for delete operation.")

    asset_group_id = None
    asset_id = None

    if args.add and (args.target_ip is None or args.asset_group_name is None):
        parser.error("--target-ip and --asset-group-name are required for add operation.")
    elif args.add:
        asset_group_id = get_asset_group_id(args.jumpserver_url, args.api_key, args.asset_group_name)

    if asset_group_id is not None:
        if args.delete:
            asset_id = get_asset_id(args.jumpserver_url, args.api_key, args.asset_group_name, args.target_ip)
            if asset_id is not None:
                delete_ip_from_asset(args.jumpserver_url, args.api_key, asset_id)
        elif args.add:
            add_ip_to_asset_group(args.jumpserver_url, args.api_key, asset_group_id, args.target_ip)

def get_asset_id(api_url, api_key, group_name, ip):
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
    }

    group_id = get_asset_group_id(api_url, api_key, group_name)

    if group_id is not None:
        response = requests.get(f'{api_url}/api/v1/assets/assets/', headers=headers, params={'group_id': group_id, 'ip': ip})

        if response.status_code == 200:
            assets = response.json().get('results', [])
            for asset in assets:
                if asset['ip'] == ip:
                    return asset['id']
            else:
                print(f"Asset with IP '{ip}' not found in group '{group_name}'.")
        else:
            print(f"Failed to retrieve assets. Status code: {response.status_code}")

    return None

if __name__ == "__main__":
    main()


"""
example:
add host:
python insert-jumpserver.py --api-key your-api-key --target-ip 192.168.1.1 --asset-group-name /Default/auto-add-test --add

del host:
python insert-jumpserver.py --api-key your-api-key --target-ip 192.168.1.1 --asset-group-name /Default/auto-add-test --delete

"""