use std::path::Path;

use async_trait::async_trait;
use loco_rs::{
    app::{AppContext, Hooks, Initializer},
    boot::{create_app, BootResult, StartMode},
    controller::AppRoutes,
    db::{self, truncate_table},
    environment::Environment,
    task::Tasks,
    worker::{Processor},
    Result,
};
use migration::Migrator;
use sea_orm::DatabaseConnection;

use crate::{controllers, models::_entities::{users}};

pub struct App;
#[async_trait]
impl Hooks for App {
    fn app_name() -> &'static str {
        env!("CARGO_CRATE_NAME")
    }

    fn app_version() -> String {
        format!(
            "{} ({})",
            env!("CARGO_PKG_VERSION"),
            option_env!("BUILD_SHA")
                .or(option_env!("GITHUB_SHA"))
                .unwrap_or("dev")
        )
    }

    async fn boot(mode: StartMode, environment: &Environment) -> Result<BootResult> {
        create_app::<Self, Migrator>(mode, environment).await
    }

    async fn initializers(_ctx: &AppContext) -> Result<Vec<Box<dyn Initializer>>> {
        Ok(vec![

        ])
    }

    fn routes(_ctx: &AppContext) -> AppRoutes {
        AppRoutes::with_default_routes().prefix("/api")
            .add_route(controllers::auth::routes())
            .add_route(controllers::user::routes())
    }

    fn connect_workers<'a>(p: &'a mut Processor, ctx: &'a AppContext) {
    }

    fn register_tasks(tasks: &mut Tasks) {
    }

    async fn truncate(db: &DatabaseConnection) -> Result<()> {
        truncate_table(db, users::Entity).await?;
        truncate_table(db, notes::Entity).await?;
        Ok(())
    }

    async fn seed(db: &DatabaseConnection, base: &Path) -> Result<()> {
        db::seed::<users::ActiveModel>(db, &base.join("users.yaml").display().to_string()).await?;
        db::seed::<notes::ActiveModel>(db, &base.join("notes.yaml").display().to_string()).await?;
        Ok(())
    }
}
