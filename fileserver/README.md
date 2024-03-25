# Description

集成了 ftp sftp samba nginx filebrowser 等服务

	USER_PASSWORD 				# ftp 及 sftp 密码,默认值 root
	SFTP_ENABLE				# 是否开启 sftp,默认值 $USERPASSWORD
	FTP_ENABLE 				# 是否开启 ftp,默认值 $USERPASSWORD
	FTP_PASV_MIN_PORT 			# ftp 被动模式下最小端口,默认值 10000
	FTP_PASV_MAX_PORT 			# ftp 被动模式下最大端口,默认值 10010
	SAMBA_ENABLE 				# 是否开启 samba
	SAMBA_USER_PASSWORD 			# samba 密码
	FILEBROWSER_USER_PASSWORD		# filesbrowser 用户密码,默认值 $USERPASSWORD


filebrowser 访问方式 http://127.0.0.1/filebrowser


dockerhub 镜像地址 https://hub.docker.com/r/qiesuijifengqifei/fileserver