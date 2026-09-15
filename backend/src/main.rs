
use axum::{routing::get, Router};
    
#[tokio::main]  //why rust doesn't have it own async runtime like nodejs? :(
async fn main(){
    let app = Router::new().route("/health", get(health));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    //not calling it, sekeleton code, just to show that it is listening on port 3000

  println!("listening on {}", listener.local_addr().unwrap());
  axum::serve(listener, app).await.unwrap();
}

async fn health() -> &'static str {
    "ok"
}