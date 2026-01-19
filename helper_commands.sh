#!/bin/bash

# Check for required environment variables
if [ -z "$FILE_NAME" ] || [ -z "$FUNCTION_NAME" ]; then
  echo "Error: FILE_NAME and FUNCTION_NAME environment variables are required."
  exit 1
fi

# Execute the Python command dynamically
python -c "import ${FILE_NAME}; ${FILE_NAME}.${FUNCTION_NAME}()"