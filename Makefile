update_compose:
	scp -i ~/.ssh/work_machine docker-compose.yaml stas@support.corp.com:~/cost_metrics/.
	scp -i ~/.ssh/work_machine .env stas@support.corp.com:~/cost_metrics/.

copy_db:
	sudo scp -i ~/.ssh/work_machine stas@support.corp.com:~/cost_metrics/db ~/code/cost_metrics/data