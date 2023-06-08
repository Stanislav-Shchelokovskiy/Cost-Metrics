update_compose:
	scp -i ~/.ssh/work_machine docker-compose.yaml stas@ubuntu-support.corp.devexpress.com:~/cost_metrics/.
	scp -i ~/.ssh/work_machine .env stas@ubuntu-support.corp.devexpress.com:~/cost_metrics/.

copy_db:
	sudo scp -i ~/.ssh/work_machine stas@ubuntu-support.corp.devexpress.com:~/cost_metrics/db ~/code/cost_metrics/data