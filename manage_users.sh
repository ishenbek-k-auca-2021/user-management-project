#!/bin/bash

# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

case "$1" in
  add)
    username="$2"
    role="$3"
    if id "$username" &>/dev/null; then
      echo "User $username already exists."
    else
      # Create user with home directory
      sudo dscl . -create /Users/$username
      sudo dscl . -create /Users/$username UserShell /bin/bash
      sudo dscl . -create /Users/$username RealName "$username"
      sudo dscl . -create /Users/$username UniqueID "$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1 | awk '{print $1+1}')"
      sudo dscl . -create /Users/$username PrimaryGroupID 20
      sudo dscl . -create /Users/$username NFSHomeDirectory /Users/$username
      sudo cp -R /System/Library/User\ Template/English.lproj /Users/$username
      sudo chown -R $username:staff /Users/$username

      echo "$username created."

      if [[ "$role" == "employee" ]]; then
        chmod 700 /Users/$username
        echo "$username is an employee with limited permissions."
      fi
    fi
    ;;

  delete)
    username="$2"
    if id "$username" &>/dev/null; then
      sudo dscl . -delete /Users/$username
      sudo rm -rf /Users/$username
      echo "$username deleted."
    else
      echo "User $username does not exist."
    fi
    ;;

  list)
    dscl . list /Users | grep -v '^_'
    ;;

  help)
    echo "Usage:"
    echo "./manage_users.sh add <username> employee"
    echo "./manage_users.sh delete <username>"
    echo "./manage_users.sh list"
    ;;

  *)
    echo "Invalid command. Use 'help' to see available commands."
    ;;
esac
