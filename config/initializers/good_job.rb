Rails.application.configure do
  config.good_job.queues = "*"
  config.good_job.max_threads = 5
  config.good_job.poll_interval = 30

  if Rails.env.production?
    config.good_job.execution_mode = :external
  else
    config.good_job.execution_mode = :async
  end

  config.good_job.cron = {
    sync_match_results: {
      cron: "*/30 * * * *",
      class: "SyncAllMatchResultsJob",
      description: "Sincroniza resultados dos jogos com a API Football a cada 30 minutos"
    }
  }
end
