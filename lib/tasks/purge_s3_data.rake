namespace :cleanup do
  desc "Remove all existing ActiveStorage attachments (reset for local)"
  task purge_active_storage: :environment do
    puts "Deleting all ActiveStorage attachments..."
    ActiveStorage::Attachment.destroy_all
    ActiveStorage::Blob.destroy_all
    puts "✅ Done!"
  end
end
