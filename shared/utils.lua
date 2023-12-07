Utils = {}

function Utils.Notify ( NotifyData )
    if IsDuplicityVersion() then
        lib.notify( NotifyData.source, {
          description = NotifyData.msg,
          duration = NotifyData.duration,
          type = NotifyData.type,
          position = 'center-right',
          style = {
            borderRadius = 0.2
          },
        })
    else
        lib.notify({
          description = NotifyData.msg,
          duration = NotifyData.duration,
          type = NotifyData.type,
          position = 'center-right',
          style = {
            borderRadius = 0.2
          },
        })
    end
end

function Utils.DrawText (action, text)
  if action == "show" then
    lib.showTextUI(text, {
        position = "left-center"
    })
  elseif action == "hide" then
    lib.hideTextUI()
  end
end

function Utils.createContext ( contextData )
  lib.registerContext(contextData)
  lib.showContext(contextData.id)
end