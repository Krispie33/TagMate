# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
user1 = User.create(username: "kris", email: "kris@test.com", password: "123456")
profile1 = Profile.create(name: "home", user: user1)
machine1 = Machine.create(type: "washer", brand: "miele", model: "W3245", profile: profile1)
drawer1 = Drawer.create(name: "white", instructions: "Wash at 40 to 60°C instead of 95°C, use a normal cycle, wash with whites only", profile: profile1)
cloth1 = Cloth.create(tag_image: "image_url", tag_data: { wash: "95", bleach: "no", dry: "low heat", iron: "medium heat", dry_clean: "no" }, cloth_image: "white_shirt_url", drawer: drawer1)
chat1 = Chat.create(title: "Washing Instructions", user: user1, drawer: drawer1)
message1 = Message.create(role: "user", content: "There are heavy stains on this shirt, how should I wash it?", chat: chat1)
