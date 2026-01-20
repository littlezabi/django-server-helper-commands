echo "Starting python env..."
source ./venv/bin/activate

cd workshift-planner-server/

# Execute based on the command
COMMAND=$1
case $COMMAND in
    activate)
        echo "Activating Python environment..."
        source ./venv/bin/activate
        ;;
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
    export)
       # Validate positional arguments
        if [ "$#" -lt 2 ]; then
            echo "Error: Missing arguments for exec command. Usage: $0 exec <module_name> <function_name>"
            exit 1
        fi
        FILE_NAME="$2"
        FUNCTION_NAME="$3"
        MODULE_PATH=$(echo "$FILE_NAME" | sed -e 's/\//./g' -e 's/.py$//')
        echo "Executing Python function '$MODULE_PATH' from module '$FILE_NAME'..."
        python -c "import os, django; os.environ.setdefault('DJANGO_SETTINGS_MODULE','core.settings'); django.setup(); from ${MODULE_PATH} import ${FUNCTION_NAME}; ${FUNCTION_NAME}()"
        ;;
      *)
        echo "Error: Unknown command '$COMMAND'"
        echo "Available commands: activate, run, shell, worker, beat, migrate, makemigrations, export"
        ;;
esac
