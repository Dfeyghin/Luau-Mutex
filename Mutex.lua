local Class = require(game.ReplicatedStorage:WaitForChild("ReplicatedScripts"):WaitForChild("Libraries", 60):WaitForChild("Class", 60))

--This simple Mutex class definition supports fairness

--USAGE:
-- in your script simply create a new Mutex object after requiring the module using local mutex = Mutex()
-- you can manually mutex:Lock() and mutex:Unlock() your code or simply use 
-- return mutex:Wrap(yourFunction())

-- Mutex is a mutual exclusion lock.
local Mutex = Class()



-- Creates a new Mutex object
function Mutex:New()
	self.blockers = {}
end

-- Lock locks the mutex. If the lock is already in use, then the calling thread
-- blocks until the lock is available.
function Mutex:Lock()
	local blocker = Instance.new("BoolValue")
	table.insert(self.blockers, blocker)
	if #self.blockers > 1 then
		blocker.Changed:Wait() -- Yield
	end
end

-- Unlock unlocks the mutex. If threads are blocked by the mutex, then the next
-- blocked mutex will be resumed.
function Mutex:Unlock()
	local blocker = table.remove(self.blockers, 1)
	if not blocker then
		error("attempt to unlock non-locked mutex", 2)
	end
	if #self.blockers == 0 then
		return
	end
	blocker = self.blockers[1]
	blocker.Value = not blocker.Value -- Resume
end

-- Wrap returns a function that, when called, locks the mutex before func is
-- called, and unlocks it after func returns. The new function receives and
-- returns the same parameters as func.
function Mutex:Wrap(func)
	return function(...)
		self:Lock()
		local results = table.pack(func(...))
		self:Unlock()
		return table.unpack(results, 1, results.n)
	end
end

return Mutex
