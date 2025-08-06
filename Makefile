NAME = inception
FILE = ./srcs/docker-compose.yml
DC = docker compose -f $(FILE) --project-name $(NAME)
VOLUME = WordPress DB
MKDIR = mkdir -p
RMDIR = rm -fr

define check
	@echo "Check '$1'..."; \
	if [ ! -e "$1" ]; then \
		echo "'$1' doesn't exist. Executing '$2'..."; \
		$2; \
	elif [ -d "$1" ]; then \
		if [ -z "$$(ls -A "$1")" ]; then \
			echo "'$1' is an empty directory. Executing '$2'..."; \
			$2; \
		else \
			echo "'$1' is a directory and not empty. Nothing to do."; \
		fi; \
	else \
		echo "'$1' already exists."; \
	fi
endef

all: haha up

dir:
	@$(MKDIR) /home/${USER}/data/wordpress
	@$(MKDIR) /home/${USER}/data/DB

haha:
	@$(call check,./srcs/.env,./srcs/requirements/tools/generate_env.sh)
	@$(call check,./secrets,./srcs/requirements/tools/generate_secrets.sh)

up: dir
	$(DC) up --build -d

status:
	$(DC) ps

maria:
	$(DC) logs mariadb

word:
	$(DC) logs wordpress

nginx:
	$(DC) logs nginx

start:
	$(DC) start

stop:
	$(DC) stop

down:
	$(DC) down --rmi all --remove-orphans -v

clean: down

fclean: clean
	su -c "$(RMDIR) /home/${USER}/data"

re: fclean all

.PHONY: all status start stop clean fclean re
