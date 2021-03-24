from urllib import request

import airflow
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from airflow.operators.postgres_operator import PostgresOperator

dag = DAG(
    dag_id = "stocksense", 
    start_date = airflow.utils.dates.days_ago(1), 
    schedule_interval = "@hourly", 
    template_searchpath = "/tmp"
)

def _get_data(year, month, day, hour, output_path, **_):
   url = (
       "https://dumps.wikimedia.org/other/pageviews/"
       f"{year}/{year}-{month:0>2}/pageviews-{year}{month:0>2}{day:0>2}-"
       f"{hour:0>2}0000.gz"
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
       # "hour": "{{ execution_date.hour }}",
       "hour": 10,
       "output_path": "/tmp/wikipageviews.gz",
   },
   dag=dag,
)

extract_gz = BashOperator(
    task_id="extract_gz",
    bash_command="gunzip --force /tmp/wikipageviews.gz",
    dag=dag,
)
 
def _fetch_pageviews(pagenames, date):
  result = dict.fromkeys(pagenames, 0)
  with open("/tmp/wikipageviews", "r", encoding = "utf-8") as f:
     for line in f:
         domain_code, page_title, view_counts, _ = line.split(" ")
         if domain_code == "en" and page_title in pagenames:
             result[page_title] = view_counts

  with open("/tmp/postgres_query.sql", "w") as f:
    for pagename, pageviewcount in result.items():
      f.write(
        "INSERT INTO pageview_counts VALUES("
        f"'{pagename}, {pageviewcount}, '{date}'"
        ");\n"
      )

fetch_pageviews = PythonOperator(
  task_id = "fetch_pageviews",
  python_callable = _fetch_pageviews,
  op_kwargs = {
    "pagenames": 
      {"Google", "Amazon", "Apple", "Microsoft", "Facebook"}, 
    "date": "{{ execution_date }}"
  },
  dag=dag
)

write_to_postgres = PostgresOperator(
  task_id = "write_to_postgres", 
  postgres_conn_id = "my_postgres", 
  sql = "postgres_query.sql",
  dag = dag
)

get_data >> extract_gz >> fetch_pageviews >> write_to_postgres
