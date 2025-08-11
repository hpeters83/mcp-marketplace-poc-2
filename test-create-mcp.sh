version=v$(date +%s)
dev_hub_url="http://localhost:7007/"
source token.sh

# Array of MCP Servers to install

mcp_array=( basic  )


replaceTemplate() {
 echo "Replacing template"
 echo "Template file: |$1|"
 echo "  Target file: |$2|"
 echo "Value to look for: |$3|"
 echo " Value to replace: |$4|"
 if [ "$1" != "$2" ]
 then
  cp "$1" "$2"
 fi
 sed -i '.bak' "s/$3/$4/g" "$2"
 echo "Added |$4| to |$2| for |$3|"
}

( replaceTemplate "./mcp/dev-hub-definitions/marketplace-mcp-basic-entry-template.yaml" "./mcp/dev-hub-definitions/marketplace-mcp-basic-entry.yaml" "@@VERSION@@" "$version")

git add . || true
git commit -m 'DevHubUpdate' || true
git push || true

# Refresh the template (TODO: Make array)
template_to_refresh='{"entityRef":"location:default/generated-0b2c17cf6ef9b0da55ab17529145f9b6e624c890"}'


# http://localhost:7007/tibco/hub/api/catalog/refresh

REFRESH_ENDPOINT="api/catalog/refresh"

sleep 3


# Delete the entry
# DELETE http://localhost:7007/tibco/hub/api/catalog/locations/b4ea63ba-07f0-4126-b6bd-48b899b58bbe

# Create the entry
# POST http://localhost:7007/tibco/hub/api/catalog/locations
# with  {"type":"url","target":"https://github.com/hpeters83/dev-hub-marketplace-entries-poc/blob/main/mcp/dev-hub-definitions/marketplace-agent-math-entry.yaml"}

# generated-0aeb1da2a7e20f017a70f9396fee9a2ab3b93d74
#



echo "curl -X POST \"$dev_hub_url$REFRESH_ENDPOINT\" -H \"Content-Type: application/json\" -H \"Authorization: Bearer $oauth2_token\" -d \"$template_to_refresh\""

curl -X POST "$dev_hub_url$REFRESH_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $oauth2_token" \
  -d "$template_to_refresh"

echo "Refreshed the template with version: $version"

sleep 5



for mcp in "${mcp_array[@]}"
do
  echo "Processing $mcp"
  # ifi-bw5-system-enhanced-template.json
  MCP_NAME="$mcp-$version"
  echo "Processing $mcp with name: $MCP_NAME"
  # ( replaceTemplate "./mcp/install-mcp-inputs/install-mcp-$mcp-template.json" "./mcp/install-mcp-inputs-tmp/install-mcp-$MCP_NAME.json" "@@AGENT_NAME@@" "$MCP_NAME")
  ( replaceTemplate "./mcp/install-mcp-inputs/install-mcp-$mcp-template.json" "./mcp/install-mcp-inputs-tmp/install-mcp-$MCP_NAME.json" "@@MCP_NAME@@" "$MCP_NAME")
  ./run-import-flow.sh $dev_hub_url "$oauth2_token" "./mcp/install-mcp-inputs-tmp/install-mcp-$MCP_NAME.json"
  # sleep 400
  # sleep 120
  sleep 5
  echo "Initiated install of agent: $MCP_NAME"
done

# ./run-import-flow.sh $dev_hub_url $oauth2_token $import_flow_input_file_send

