# {{ cookiecutter.image_pretty_name }}

{{ cookiecutter.image_description }}

Documentation: {{ cookiecutter.image_docs_url }}

## Usage

You can map your local `/etc/{{ cookiecutter.image_slug }}` to configure new containers. Example:

```sh
docker run --rm -v /etc/{{ cookiecutter.image_slug }}:/etc/{{ cookiecutter.image_slug }}:ro {{ cookiecutter.image_slug }}:{{ cookiecutter.image_tag }} example-tool --do-something
```

## Environment variables

This image supports the following environment variables:

| **Variable** | **Description** | **Required** | **Example** |
|--------------|-----------------|:------------:|:-----------:|
| `PG_HOST` | Postgres server host | yes | `127.0.0.1` |
| `PG_PORT` | Postgres server port | yes | `5432` |
| `PG_DBNAME` | The database name | yes | `example_production` |
| `PG_USER` | The Postgres user | yes | `example` |
| `PG_PASS` | The user password | yes | `mysuperpass` |
