*This project has been created as part of the 42 curriculum by arazafin.*

# Inception

## Description

The **Inception** project is a core 42 curriculum project designed to introduce students to system administration through the use of **Docker**. The goal is to set up a small infrastructure entirely on a virtual machine using Docker Compose.

The infrastructure consists of several interconnected containers:
- **Nginx**: Acting as the entry point with TLS 1.3 encryption.
- **WordPress**: Running with PHP-FPM to serve the website content.
- **MariaDB**: Providing the database backend for WordPress.

This project emphasizes security, networking, and volume management within a containerized environment.

## Instructions

### Prerequisites
- A Linux environment (preferably Debian or Alpine-based as per subject requirements).
- **Docker** and **Docker Compose** installed.
- **Make** utility.

### Installation & Execution
To set up and run the infrastructure, follow these steps:

1.  **Clone the repository**:
    ```bash
    git clone <repository_url>
    cd inception
    ```

2.  **Build and launch**:
    ```bash
    make
    ```
    This command will automatically generate necessary environment variables, create local data directories, and launch the containers via `docker-compose`.

3.  **Manage the project**:
    - `make status`: View the state of your containers.
    - `make stop`: Stop the running services.
    - `make clean`: Remove containers and networks.
    - `make fclean`: Deep clean including volumes and local data.

## Resources

### Documentation
- [Official Docker Documentation](https://docs.docker.com/)
- [Docker Compose Overview](https://docs.docker.com/compose/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)
- [WordPress and PHP-FPM](https://wordpress.org/support/article/nginx/)


## Project Description (Technical Details)

### Docker Usage and Sources
All images in this project are built from scratch using official parent images (like Alpine Linux). No pre-built images from Docker Hub (other than base OS) are used for the main services. The source files are organized in the `srcs/` directory:
- `srcs/docker-compose.yml`: Defines the services, networks, and volumes.
- `srcs/requirements/`: Contains Dockerfiles and configuration scripts for each service.

### Design Choices
- **Alpine Linux**: Chosen for its lightweight footprint and security-first approach.
- **Service Isolation**: Each container runs exactly one process (PID 1), adhering to the Docker philosophy.
- **TLS 1.3**: Mandatory for all external connections to the Nginx server.

### Comparisons

#### Virtual Machines vs Docker
| Feature | Virtual Machines | Docker |
| :--- | :--- | :--- |
| **Kernel** | Separate kernel for each VM | Shared host kernel |
| **Size** | Large (GBs) | Lightweight (MBs) |
| **Start Time** | Minutes | Seconds |
| **Abstraction** | Hardware-level | App-level |

#### Secrets vs Environment Variables
| Feature | Environment Variables | Docker Secrets |
| :--- | :--- | :--- |
| **Visibility** | Plain text (`docker inspect`, `env`) | Encrypted at rest, mounted in memory |
| **Persistence** | Stored in image/container config | Only accessible to authorized services |
| **Usage** | General config (ports, usernames) | Sensitive data (passwords, SSH keys) |

#### Docker Network vs Host Network
| Feature | Docker Network (Bridge) | Host Network |
| :--- | :--- | :--- |
| **Isolation** | High (isolated subnet) | None (shares host's stack) |
| **Performance** | Slight overhead due to NAT | No overhead |
| **Security** | Firewall-friendly | Direct exposure |

#### Docker Volumes vs Bind Mounts
| Feature | Docker Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Management** | Managed by Docker (`/var/lib/docker/volumes`) | Managed by User (any path on host) |
| **Portability** | High (independent of host structure) | Low (linked to host paths) |
| **Performance** | Optimized for high I/O | Direct host filesystem access |
