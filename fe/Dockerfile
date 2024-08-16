# Use the official Nginx image as a parent image
FROM nginx:alpine

# Remove the default Nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy your static site content into the container
COPY ./ /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]