dir = 'src'
port = 5000

guard 'process', name: 'Shiny', command: ['R', '-e', "shiny::runApp('#{dir}', port = #{port})"] do
  watch(%r{#{dir}/.+\.R$})
end

guard 'livereload', grace_period: 0.5 do
  watch(%r{#{dir}/.+\.R$})
end
