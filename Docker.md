Steps for Setting Global Memory Limit (Advanced):
Use Cgroups: Control groups (cgroups) in Linux can be used to limit the memory usage of the Docker daemon and, by extension, all containers it runs. This is a complex task and requires a good understanding of Linux system administration.

Modify System Service File: You can modify the Docker service file to include resource limits. This involves editing the service file (/lib/systemd/system/docker.service) and adding directives under the [Service] section to limit memory usage. For example, adding MemoryLimit=255G would limit the total memory used by the Docker daemon and all its containers to 255GB.

Apply and Restart: After modifying the service file, reload the daemon and restart the Docker service:

bash
Copy code
sudo systemctl daemon-reload
sudo systemctl restart docker