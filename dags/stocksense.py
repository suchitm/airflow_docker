from urllib import request

import airflow
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator

dag = DAG(
    dag_id = "stocksense", 
    start_date = airflow.utils.dates.days_ago(1), 
    schedule_interval = "@hourly", 
)

def _get_data(year, month, day, hour, output_path, **_):
   url = (
       "https://dumps.wikimedia.org/other/pageviews/"
       f"{year}/{year}-{month:0>2}/pageviews-{year}{month:0>2}{day:0>2}-{hour:0>2}0000.gz"
   )
   print(url)
   request.urlretrieve(url, output_path)

get_data = PythonOperator(
   task_id="get_data",
   python_callable=_get_data,
   op_kwargs={
       "year": "{{ execution_date.year }}",
       "month": "{{ execution_date.month }}",
       "day": "{{ execution_date.day }}",
       "hour": "{{ execution_date.hour }}",
       "output_path": "/tmp/wikipageviews.gz",
   },
   dag=dag,
)

extract_gz = BashOperator(
    task_id="extract_gz",
    bash_command="gunzip --force /tmp/wikipageviews.gz",
    dag=dag,
)
 
 
def _fetch_pageviews(pagenames):
   result = dict.fromkeys(pagenames, 0)
   with open(f"/tmp/wikipageviews", "r") as f:
       for line in f:
           domain_code, page_title, view_counts, _ = line.split(" ")
           if domain_code == "en" and page_title in pagenames:
               result[page_title] = view_counts
 
   print(result)
 
fetch_pageviews = PythonOperator(
    task_id="fetch_pageviews",
    python_callable=_fetch_pageviews,
    op_kwargs={"pagenames": {"Google", "Amazon", "Apple", "Microsoft", "Facebok"}},
    dag=dag,
)

get_data >> extract_gz >> fetch_pageviews
