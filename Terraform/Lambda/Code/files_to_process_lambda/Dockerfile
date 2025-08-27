FROM public.ecr.aws/lambda/python:3.12

COPY daily_monitor_lambda.py ${LAMBDA_TASK_ROOT}

CMD ["files_to_process_lambda.lambda_handler"]
