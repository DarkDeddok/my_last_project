@echo off

call env.bat

oc delete project %APP_NAME%
