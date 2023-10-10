@echo off
	echo "---------- Generate passwords ----------"
	setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
	set len=32
	set charpool=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
	set len_charpool=61
	set mas_len=13
	mkdir .deploy
	if exist .deploy\GEN_PWD.txt (
		del .deploy\GEN_PWD.txt
	)	
	cd .deploy
	set count=0
	:GenPasswords
	set /a count+=1
	set gen_str=
	for /L %%b IN (1, 1, %len%) do (
		set /A rnd_index=!RANDOM! * %len_charpool% / 32768
		for /F %%i in ('echo %%charpool:~!rnd_index!^,1%%') do set gen_str=!gen_str!%%i
	)

	if %count% equ 1 echo REDIS_PASSWORD=!gen_str!>> GEN_PWD.txt
	if %count% equ 2 echo RABBITMQ_PASSWORD=!gen_str!>> GEN_PWD.txt
	if %count% equ 3 echo DB_ROOT_PASSWORD=!gen_str!>> GEN_PWD.txt
	if %count% equ 4 echo JKS_PASSWORD=!gen_str!>> GEN_PWD.txt
	if %count% equ 5 echo JKS_KEY_PASSWORD=!gen_str!>> GEN_PWD.txt
	if %count% equ 6 echo COOKIE_KEY_PASS=!gen_str!>> GEN_PWD.txt
	if %count% equ 7 echo COMMON_KEY_PASS=!gen_str!>> GEN_PWD.txt
	if %count% equ 8 echo VAULT_KEY_PASS=!gen_str!>> GEN_PWD.txt
	if %count% equ 9 echo RABBIT_JKS_KEY_PASSWORD=!gen_str!>> GEN_PWD.txt
	if %count% equ 10 echo CASSANDRA_PASSWORD=!gen_str!>> GEN_PWD.txt
	if %count% equ 11 echo OPENIAM_DB_PASSWORD=!gen_str!>> GEN_PWD.txt
	if %count% equ 12 echo ACTIVITI_DB_PASSWORD=!gen_str!>> GEN_PWD.txt
    if %count% equ 13 echo ELASTICSEARCH_PASSWORD=!gen_str!>> GEN_PWD.txt

    if !count! leq !mas_len! goto GenPasswords
	
	cd ..

    endlocal