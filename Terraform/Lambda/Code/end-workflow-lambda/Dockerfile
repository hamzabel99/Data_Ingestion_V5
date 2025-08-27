FROM public.ecr.aws/lambda/python:3.12

COPY daily_monitor_lambda.py ${LAMBDA_TASK_ROOT}

CMD ["end-workflow-lambda.lambda_handler"]
