# https://aws.amazon.com/blogs/containers/announcing-amazon-ecs-task-definition-deletion/

# Get the list of inactive task definition ARNs
TASK_DEFINITIONS=$(aws ecs list-task-definitions --status INACTIVE --query 'taskDefinitionArns' --output json --no-cli-pager)

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is not installed. Please install jq to proceed."
    exit 1
fi

# Loop through the ARNs and deregister each task definition
echo "${TASK_DEFINITIONS}" | jq -r '.[]' | while read -r task_definition_arn; do
    aws ecs delete-task-definitions --task-definitions "${task_definition_arn}" --no-cli-pager
    echo "Deleted task definition: ${task_definition_arn}"
    sleep 5
done
