# Update the system
sudo yum update -y

# Install nginx
sudo yum install -y nginx

# Start nginx service
sudo systemctl start nginx

# Enable nginx to start on boot
sudo systemctl enable nginx

# Create a simple HTML page
sudo bash -c 'cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Lab 1 - Cloud Computing</title>
</head>
<body>
    <h1>Welcome to Lab 1!</h1>
    <p>This web server is running on EC2 in a public subnet.</p>
</body>
</html>
EOF'

# Restart nginx to serve the new content
sudo systemctl restart nginx

# Verify nginx is running
sudo systemctl status nginx
