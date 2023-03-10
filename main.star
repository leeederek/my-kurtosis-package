nginx_conf_template = read_file("github.com/leeederek/my-kurtosis-package/default.conf.tmpl")

def run(plan, args):
    rest_service = plan.add_service(
        "hello-world",
        config = ServiceConfig(
            image = "vad1mo/hello-world-rest",
            ports = {
                "http": PortSpec(number = 5050),
            },
        ),
    )

    nginx_conf_data = {
        "HelloWorldIpAddress": rest_service.ip_address,
        "HelloWorldPort": rest_service.ports["http"].number,
    }

    nginx_config_file_artifact = plan.render_templates(
        name = "nginx-artifact",
        config = {
            "default.conf": struct(
                template = nginx_conf_template,
                data = nginx_conf_data,
            )
        },
    )

    nginx_count = 1
    if hasattr(args, "nginx_count"):
        nginx_count = args.nginx_count

    for i in range(0, nginx_count):
        plan.add_service(
            "my-nginx-" + str(i),
            config = ServiceConfig(
                image = "nginx:latest",
                ports = {
                    "http": PortSpec(number = 80),
                },
                files = {
                    "/etc/nginx/conf.d": nginx_config_file_artifact,
                }
            ),
        )
