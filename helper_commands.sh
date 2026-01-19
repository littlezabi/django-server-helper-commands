#!/bin/bash

# Welcome Message
echo "Starting python env..."
source ./venv/bin/activate

cd workshift-planner-server/

# Execute based on the command
case $COMMAND in
    run)
        echo "Starting Django development server..."
        python manage.py runserver
        ;;
    shell)
        echo "Starting Django shell..."
        python manage.py shell
        ;;
    worker)
        echo "Starting Celery worker..."
        celery -A core worker --loglevel=info
        ;;
    beat)
        echo "Starting Celery beat..."
        celery -A core beat --loglevel=info
        ;;
    migrate)
        echo "Running migrations..."
        python manage.py migrate
        ;;
    makemigrations)
        echo "Creating migrations..."
        python manage.py makemigrations
        ;;
    env)
        echo "Activating environment..."
        source ./venv/bin/activate
        ;;
    exec)
        if [ -z "$FILE_NAME" ] || [ -z "$FUNCTION_NAME" ]; then
            echo "Error: FILE_NAME and FUNCTION_NAME environment variables are required."
            exit 1
        fi
        echo "Executing Python custom function..."
        python -c "import os, django; os.environ.setdefault('DJANGO_SETTINGS_MODULE','core.settings'); django.setup(); from ${FILE_NAME} import ${FUNCTION_NAME}; ${FUNCTION_NAME}()"
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        echo "Available commands: run, shell, worker, beat, migrate, makemigrations, env, exec"
        ;;
esac
