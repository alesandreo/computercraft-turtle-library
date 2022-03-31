modem = peripheral.wrap("top")
if not modem then
    error("modem not found")
end

CommandModule = {
    known_clients = {

    },

}

Minion = {
    id = nil,

}

while true do
    event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    os.sleep(1)
    modem.transmit(replyChannel, senderChannel, "EHLO")
end


function processMessage(event, modemSide, senderChannel, replyChannel, message, senderDistance)
    error("unfinished")
end
