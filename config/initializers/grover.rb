Grover.configure do |config|
  config.options = {
    executable_path: ENV['PUPPETEER_EXECUTABLE_PATH'] || '/usr/bin/chromium-browser',
    launch_args: [
      '--no-sandbox',                # Essencial para rodar como root no Docker
      '--disable-setuid-sandbox',    # Camada extra de segurança que causa erro em containers
      '--disable-dev-shm-usage',     # FORÇA o uso da RAM normal em vez de /dev/shm (Mata o erro de Target Close)
      '--disable-gpu',               # Não precisamos de aceleração gráfica para PDF
      '--no-zygote',                 # Economiza memória ao não criar processos filhos desnecessários
      '--single-process'             # Roda tudo em uma única thread (melhor para instâncias pequenas)
    ],
    wait_until: 'networkidle0', # Espera todas as requisições terminarem
    timeout: 30000
  }
end
