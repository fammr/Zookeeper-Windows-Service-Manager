::zookeeper windows����װ������
::ͨ��������������ʵ��zookeeperϵͳ����İ�װж�أ������͹ر�
::xiangyuecn��д��ѧϰzookeeper֮�ã���ûŪ����ô����zookeeper���ȰѰ�װ�����Ƚ���ˣ���Ȼ������һע��zookeeperҲ�Զ��ص���
::2018-07-21

::˵����
::��1���ѡ�5���ڵ��ļ��ŵ�zookeeper��Ŀ¼���������start.bat����
::��2�������������Ȱ�װ����װ�ɹ��󽫻����ж�ع��ܣ�������������������Ҳ������������û�к����˵Ĵ���˵����
::��3����װ�����ɵ�winswXXX.xml�ļ�����ɾ���������޷�ж�غ�����
::��4������������winsw�����3��log�ļ�������ɾ��
::��5���˳�����
::		start.bat ���ű�
::		tp.vbs �����ļ����ɽű�
::		winsw1.9.exe windows����װ�������ص�ַ��http://download.java.net/maven/2/com/sun/winsw/winsw/ ���ý��ܣ�https://kenai.com/projects/winsw/pages/ConfigurationSyntax
::	�⼸���ļ���ɣ�ȱһ����

@echo off

::���ò���---------------------------

::��ѡ�Ǹ�Ŀ¼����ģ�壬���ز�������
set configTxt=D:\Works\�ĵ�\���������ļ�\zookeeper\config-local.txt
if not exist %configTxt% (
	set configTxt=
)

::�����ļ���
set confPath=conf\zoo.cfg
::��װ��·������Ҫ��׺
set svsInstall=winsw1.9
::��������
set svs=Zookeeper

::ִ�в���---------------------------
color 8f

:main
set dir=%~d0%~p0
set dirPath=%dir:~0,-1%
set stack=
set stackErr=0
%~d0
cd %dir%

cls
echo               *****˵�������뿴Դ���� by xiangyuecn ���ݺ���*****
echo.
if not "%msg%"=="" echo -------%msg%-------

set msg=
set datetime=%date:~0,10% %time:~0,8%
set isRun=false
set isInstall=true
sc query %svs%|findstr /c:"ָ���ķ���δ��װ">nul&&set isInstall=false
sc query %svs%|findstr /ic:"run">nul&&set isRun=true

if %isRun%==true (
	echo %datetime% %svs%����������...
) else (
	echo %datetime% %svs%����δ����xxx
)

echo ���Բ�����
if not %isRun%==true echo   1:����
if %isRun%==true (
	echo   2:ֹͣ
	echo   3:����
)
echo   4:��ģ���������
echo        ���ڸ�Ŀ¼�½�config.txt�ļ���"%configTxt%"����ʽ(h)
echo.
echo   5:�˳�
echo.
if %isInstall%==false (
	echo   0:��װ����
) else (
	echo   0:ж�ط���/�ָ�%svsInstall%.xml����
)

set step=
set /p step=���������:
echo.

if "%step%"=="0" goto step_install
if "%step%"=="1" goto step_run
if "%step%"=="2" goto step_stop
if "%step%"=="3" goto step_reset
if "%step%"=="4" goto step_tpconfig
if "%step%"=="5" exit
if "%step%"=="h" goto tpconfighelp

goto step_end

:tpconfighelp
cls
echo	config.txt�ļ����ø�ʽ��
echo          ����֧��ʱ�����
echo              ��:logs/access_{y}{m}{d} {h}{M}{s}.log
echo              Ϊ:logs/access_20130306 122530.log
echo.
echo          ����֧�ֺ궨����滻
echo              DEF(��ʶ) ������=������ (��ʶ)END
echo              ������֧��^&��^<��^>��/��_��-���ո񡢻��С���ĸ�����֡�������ϣ������ݿ��Զ���
pause
goto step_end

:step_run
	if not %isRun%==true (
		echo ������...
		net start %svs%
		if errorlevel 1 (
			set stackErr=1
			set msg=������������ʧ�ܣ���
			pause
		) else (
			set isRun=true
			set msg=����������
		)
	)
	goto step_end

:step_stop
	if %isRun%==true (
		echo �ر���...
		net stop %svs%
		if errorlevel 1 (
			set stackErr=1
			set msg=�����رշ���ʧ�ܣ���
			pause
		) else (
			set isRun=false
			set msg=�ѹرշ���
		)
	)
	goto step_end

:step_reset
	if %isRun%==true (
		echo ������...
		
		set stack=step_reset_stop
		set stackErr=0
		goto step_stop
		:step_reset_stop
		if %stackErr%==0 (
			set stack=step_reset_run
			goto step_run
			:step_reset_run
			set stack=
		)
		
		if %stackErr%==0 (
			set msg=�����ɹ�
		) else (
			set msg=%msg%!!��������!!
		)
	)
	goto step_end


:step_tpconfig
	if "%configTxt%"=="" (
		set tpPath=%dir%config.txt
	) else (
		set tpPath=%configTxt%
	)
	if not exist %tpPath% (
		set stackErr=1
		echo %tpPath%�����ڣ����ȴ������ļ�������Ϊzoo_sample.cfg�ĸ���
		pause
	) else (
		echo ������������...
		
		cscript tp.vbs %tpPath% %dir%%confPath%
		if ERRORLEVEL 1 (
			set stackErr=1
			set ms=����ִ����������ʧ�ܣ���
			pause
		) else (
			set msg=����������
		)
	)
	goto step_end


:step_install
	if %isInstall%==true goto step_uninstall
	echo ���ڰ�װ...

	set stack=step_install_getxml
	set stackErr=0
	goto fn_getInstallXML
	:step_install_getxml
	set stack=

	%svsInstall%.exe install
	set msg=��ִ�а�װ����״̬��ȷ��
	goto step_end

:step_uninstall
	set useUninstall=
	echo ȷ��ɾ������������y,�ָ���ɾ����h��
	set /p useUninstall=
	if "%useUninstall%"=="h" (
		set stack=step_uninstall_getxml
		set stackErr=0
		goto fn_getInstallXML
		:step_uninstall_getxml
		set stack=
		goto step_uninstall_getxml_exit
	) else (
		if "%useUninstall%"=="y" (
			set stack=step_uninstall_stop
			set stackErr=0
			goto step_stop
			:step_uninstall_stop
			set stack=
			
			if %stackErr%==0 (
				echo ����ж��...
				%svsInstall%.exe uninstall
				set msg=��ִ��ж�أ���״̬��ȷ��
			) else (
				set msg=%msg%����ж��ʧ�ܣ���
			)
		)
	)
	:step_uninstall_getxml_exit
	goto step_end

:step_end
	if "%stack%"=="" (
		cls
		goto main
	) else (
		goto %stack%
	)

:fn_getInstallXML
	echo ^<?xml version="1.0" encoding="GBK"?^>>%svsInstall%.xml
	echo ^<service^>>>%svsInstall%.xml
	echo 	^<!-->>%svsInstall%.xml
	echo 	��װ����>>%svsInstall%.xml
	echo 	cmd:^>winws.exe install>>%svsInstall%.xml
	echo 	ж�ط���>>%svsInstall%.xml
	echo 	cmd:^>winws.exe uninstall>>%svsInstall%.xml
	echo 	--^>>>%svsInstall%.xml
	echo 	^<id^>%svs%^</id^>>>%svsInstall%.xml
	echo 	^<name^>%svs%^</name^>>>%svsInstall%.xml
	echo 	^<description^>%svs%�����ɰ�װ����װ�����ñ���װ��ж��^</description^>>>%svsInstall%.xml
	echo 	^<!--��������--^>>>%svsInstall%.xml
	echo 	^<depend^>^</depend^>>>%svsInstall%.xml
	echo 	^<!--ִ�г���·��--^>>>%svsInstall%.xml
	echo 	^<executable^>java^</executable^>>>%svsInstall%.xml
	echo 	^<!--��־Ŀ¼--^>>>%svsInstall%.xml
	echo 	^<logpath^>%dir%^</logpath^>>>%svsInstall%.xml
	echo 	^<!--��־��¼��ʽreset roll append--^>>>%svsInstall%.xml
	echo 	^<logmode^>append^</logmode^>>>%svsInstall%.xml
	echo 	^<!--����--^>>>%svsInstall%.xml
	echo 	^<arguments^>"-Dzookeeper.log.dir=%dirPath%" "-Dzookeeper.root.logger=INFO,CONSOLE" -cp "%dir%*;%dir%lib\*;%dir%conf" org.apache.zookeeper.server.quorum.QuorumPeerMain "%dir%%confPath%"^</arguments^>>>%svsInstall%.xml
	echo ^</service^>>>%svsInstall%.xml
	goto %stack%