FROM alpine:3.8

USER root
WORKDIR /root

# Fetch the latest apk manifests
# Update existing packages
# Install bash and vim
# Cleanup after ourselves to keep this layer as small as possible
# Details: https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management
RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash vim sudo

# Add a group named "appusers"
#   -g, Assign this ID to the new group
# Details: https://busybox.net/BusyBox.html#addgroup
RUN addgroup -g 1000 appusers

# 
# Add 'root' to the 'appusers' group 
#
RUN addgroup root appusers

# Add a user named "appuser"
#   -D, Do not assign a password
#   -u, Assign this ID to the new user
#   -s, Set this shell as the user's default login shell 
#   -h, Set this home path as the user's home path
#   -G, Add the new user to an existing group
# Details: https://busybox.net/BusyBox.html#adduser
RUN adduser -D -u 1000 -s /bin/bash -h /home/appuser -G appusers appuser

# Alpine Linux default shell for root is '/bin/ash'
# Change this to '/bin/bash' so that  '/etc/bashrc'
# can be loaded when entering the running container
RUN sed -i 's,/bin/ash,/bin/bash,g' /etc/passwd

# Add the 'appusers' group to the sudoers file
# No password required
RUN echo '%appusers ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Add our custom welcome message script to profile.d.
# This is automatically sourced by /etc/profile when
# switching users.
COPY scripts/etc/profile.d/welcome.sh /etc/profile.d/welcome.sh

COPY scripts/etc/bashrc /etc/bashrc

COPY scripts/usr/share/entrypoint.sh /usr/share/entrypoint.sh

# Must set this value for the bash shell to source 
# the '/etc/bashrc' file.
# See: https://stackoverflow.com/q/29021704
ENV BASH_ENV /etc/bashrc

# Use this path to save runtime variables persisted 
# across user sessions.
RUN mkdir -p /usr/share/entrypoint \
    && chown appuser:appusers /usr/share/entrypoint

USER appuser
WORKDIR /home/appuser

# This is the last necessary piece for loading the
# '/etc/bashrc' file. The 'exec' syntax 
ENTRYPOINT [ "/usr/share/entrypoint.sh" ]

CMD [ "bash" ]
