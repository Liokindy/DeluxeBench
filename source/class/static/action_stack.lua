ActionStack = {}

ActionStack.redoStack = {}
ActionStack.undoStack = {}

function ActionStack.actionLoadSFDItem(path)
    local command = {}
    command.type = "load_sfd_item"
    command.context = {}
    command.context.path = path
    command.context.index = #App.loadedItems + 1
    command.context.item = SFDItem.fromBinary(ByteStream.fromFile(command.context.path))

    for i=1, #App.loadedItems do
        if (App.loadedItems[i] == nil) then
            command.context.index = i
            break
        end
    end

    command.doAction = function ()
        App.loadedItems[command.context.index] = command.context.item
        App.ui.middle.primaryPanel:refreshLoaded()
    end

    command.undoAction = function ()
        App.loadedItems[command.context.index] = nil
        App.ui.middle.primaryPanel:refreshLoaded()
    end

    ActionStack.perform(command)
end

function ActionStack.actionLoadSFDAnimations(path)
    local command = {}
    command.type = "load_sfd_animations"
    command.context = {}
    command.context.path = path
    command.context.animations = SFDAnimation.fromBinary(ByteStream.fromFile(command.context.path))

    command.doAction = function ()
        for i, animation in ipairs(command.context.animations) do
            local index = #App.loadedAnimations + 1

            for i=1, #App.loadedAnimations do
                if (App.loadedAnimations[i] == nil) then
                    command.context.index = i
                    break
                end
            end

            table.insert(App.loadedAnimations, index, animation)
        end

        App.ui.middle.primaryPanel:refreshLoaded()
    end

    command.undoAction = function ()
        local indices = {}

        for j, animation2 in ipairs(command.context.animations) do
            for i, animation in ipairs(App.loadedAnimations) do
                if (animation == animation2) then
                    table.insert(indices, i)
                end
            end
        end

        for i, index in ipairs(indices) do
            App.loadedAnimations[index] = nil
        end

        App.ui.middle.primaryPanel:refreshLoaded()
    end

    ActionStack.perform(command)
end

function ActionStack.perform(command)
    command.doAction()

    table.insert(ActionStack.undoStack, command)
    ActionStack.redoStack = {}
end

function ActionStack.undo()
    local command = table.remove(ActionStack.undoStack)

    if (command) then
        command.undoAction()
        table.insert(ActionStack.redoStack, command)
    end
end

function ActionStack.redo()
    local command = table.remove(ActionStack.redoStack)

    if (command) then
        command.doAction()
        table.insert(ActionStack.undoStack, command)
    end
end
