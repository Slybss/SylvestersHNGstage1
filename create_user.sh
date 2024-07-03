Here is a possible implementation of the bash script:

bash
#!/bin/bash

# Set the log file and password file
LOG_FILE=/var/log/user_management.log
PASSWORD_FILE=/var/secure/user_passwords.txt

# Function to create a user and group
create_user() {
  username=$1
  groups=$2

  # Create the user group
  groupadd ${username}

  # Create the user and set the password
  useradd -m -g ${username} -G ${groups} ${username}
  password=$(generate_password)
  echo "${username}:${password}" | chpasswd

  # Set ownership and permissions for the home directory
  chown ${username}:${username} /home/${username}
  chmod 700 /home/${username}

  # Log the action
  echo "Created user ${username} with groups ${groups}" >> ${LOG_FILE}
}

# Function to generate a random password
generate_password() {
  < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32}; echo
}

# Read the input file
while IFS=';' read -r username groups; do
  # Ignore whitespace
  username=$(echo ${username} | tr -d '[:space:]')
  groups=$(echo ${groups} | tr -d '[:space:]')

  # Create the user and group
  create_user ${username} ${groups}
done < "$1"

# Write the passwords to the password file
echo "Username,Password" > ${PASSWORD_FILE}
for user in $(cut -d: -f1 ${PASSWORD_FILE}); do
  password=$(grep ${user} ${PASSWORD_FILE} | cut -d: -f2)
  echo "${user},${password}" >> ${PASSWORD_FILE}
done

# Set permissions for the password file
chmod 600 ${PASSWORD_FILE}
