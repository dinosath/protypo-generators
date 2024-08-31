{% set file_name= rootFolder ~"/src/bin/main.rs" %}
to: {{file_name}}
message: "File `{{file_name}}` was created successfully."
===
use loco_rs::cli;
use {{ applicationName }}::app::App;
use migration::Migrator;

#[tokio::main]
async fn main() -> loco_rs::Result<()> {
    cli::main::<App, Migrator>().await
}
