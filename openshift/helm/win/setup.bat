@echo off

call env.bat

:: Set password variables from file
if not exist .deploy\GEN_PWD.txt (
	echo "Need generate passwords file before start setup-helm"
	pause
	exit 1
)	
for /f "delims== tokens=1,2" %%G in (.deploy\GEN_PWD.txt) do SET %%G=%%H
echo "---------- Generate passwords : Done ----------"

mkdir .deploy

powershell -command "get-content 'yaml\mariadb.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\mariadb.values.yaml'"
powershell -command "get-content 'yaml\postgresql.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\postgresql.values.yaml'"
powershell -command "get-content 'yaml\redis.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\redis.values.yaml'"
powershell -command "get-content 'yaml\cassandra.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\cassandra.values.yaml'"
powershell -command "get-content 'yaml\openiam.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\openiam.values.yaml'"
powershell -command "get-content 'yaml\openiam-pvc.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\openiam-pvc.values.yaml'"
powershell -command "get-content 'yaml\openiam-rproxy.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\openiam-rproxy.values.yaml'"
powershell -command "get-content 'yaml\openiam-gremlin.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\openiam-gremlin.values.yaml'"
powershell -command "get-content 'yaml\openiam-vault.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\openiam-vault.values.yaml'"
powershell -command "get-content 'yaml\openiam-configmap.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\openiam-configmap.values.yaml'"
powershell -command "get-content 'yaml\kibana.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\kibana.values.yaml'"
powershell -command "get-content 'yaml\consul.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\consul.values.yaml'"
powershell -command "get-content 'yaml\hbase.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\hbase.values.yaml'"
powershell -command "get-content 'yaml\elasticsearch.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\elasticsearch.values.yaml'"
powershell -command "get-content 'yaml\rabbitmq.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\rabbitmq.values.yaml'"
powershell -command "get-content 'yaml\filebeat.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\filebeat.values.yaml'"
powershell -command "get-content 'yaml\metricbeat.values.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\metricbeat.values.yaml'"

powershell -command "get-content 'yaml\role-binding-for-sc.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\role-binding-for-sc.yaml'"
powershell -command "get-content 'yaml\role-for-sc.yaml' | foreach { [System.Environment]::ExpandEnvironmentVariables($_) } | set-content -path '.deploy\role-for-sc.yaml'"