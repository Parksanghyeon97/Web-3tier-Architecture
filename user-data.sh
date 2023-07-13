#!/bin/bash

yum install -y httpd
yum install -y php php-mysqlnd
systemctl start httpd && systemctl enable httpd

cat > /var/www/html/index.php <<EOF
<?php
\$servername = "${db_address}";
\$username = "${db_username}";
\$password = "${db_password}";
\$dbname = "${db_name}";

\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

\$sql = "SELECT age, name, PhoneNumber FROM users";
\$result = \$conn->query(\$sql);

if (\$result->num_rows > 0) {
    while(\$row = \$result->fetch_assoc()) {
        echo "Age: " . \$row["age"] . " - Name: " . \$row["name"] . " - Phone Number: " . \$row["PhoneNumber"] . "<br>";
    }
} else {
    echo "0 results";
}

\$conn->close();
?>
EOF