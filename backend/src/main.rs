use axum::{extract::State, http::StatusCode, routing::get, Router};
use sqlx::{postgres::PgPoolOptions, PgPool};

#[tokio::main]
async fn main(){ 
  dotenvy::dotenv().ok();
  let database_url = std::env::var("DATABASE_URL").expect("DATABASE_URL must be set cutie");
  let pool = PgPoolOptions::new()
    .max_connections(5)
    .connect(&database_url)
    .await
    .expect("Failed to create postgres connection pool");

  sqlx::migrate!()
    .run(&pool)
    .await
    .expect("Failed to run database migrations");

  let app = Router::new()
    .route("/health", get(health))
    .route("/health/db", get(health_db))
    .with_state(pool);

  let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
    .await
    .expect("Failed to bind to address");

  println!("listening on {}", listener.local_addr().unwrap());
  axum::serve(listener, app).await.unwrap();

}

async fn health() -> &'static str {
  "ok"
}

async fn health_db(State(pool): State<PgPool>) -> (StatusCode, &'static str) {
   match sqlx::query("select 1").fetch_one(&pool).await {
        Ok(_) => (StatusCode::OK, "db ok"),
        Err(err) => {
            eprintln!("db health check failed: {err}");
            (StatusCode::SERVICE_UNAVAILABLE, "db is maybe unavailable check logs for more info")
        }
    }
}

