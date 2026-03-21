Grover.configure do |config|
  config.options = {
    executable_path: ENV['PUPPETEER_EXECUTABLE_PATH'] || nil,
    launch_args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--single-process'
    ],
    print_background: true,
    display_header_footer: false,
    prefer_css_page_size: true
  }
end
