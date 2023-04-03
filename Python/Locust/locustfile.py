from json import JSONDecodeError
from locust import HttpUser, task, between


class User(HttpUser):
    wait_time = between(0, 2)

    @task
    def check_inference(self):
        with self.client.get(
            "/cpu_load",
            catch_response=True
        ) as response:
            if response.status_code != 200:
                print(response.status_code, response.text)
