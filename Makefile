NAME = inception
FILE = ./srcs/docker-compose.yml
DC = docker compose
C = $(DC) -f $(FILE) --project-name $(NAME)
VOLUME = WordPress DB
MKDIR = mkdir -p
RMDIR = rm -fr

define check_env
	@echo "Vérification de l'existence de '$1'..." ; \
	if [ ! -f "$1" ]; then \
		echo "'$1' n'existe pas. Exécution de '$2'..." ; \
		$2 ; \
	else \
		echo "'$1' existe déjà. Pas besoin d'exécuter le script." ; \
	fi
endef

all: haha

dir:
	@$(MKDIR) /home/${USER}/data/wordpress
	@$(MKDIR) /home/${USER}/data/DB

haha:
	$(call check_env,./srcs/.env,./srcs/requirements/tools/generate_env.sh)

up: dir
	$(C) up --build -d

status:
	$(C) ps

maria:
	$(C) logs mariadb

word:
	$(C) logs wordpress

nginx:
	$(C) logs nginx

start:
	$(C) start

stop:
	$(C) stop

down:
	$(C) down --rmi all --remove-orphans -v

clean: down

fclean: clean
	$(RMDIR) /home/${USER}/data

re: fclean all

.PHONY: all status start stop clean fclean re
