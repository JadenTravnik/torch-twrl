local function selectAction(client, instance_id, state, envDetails, agent)
   -- autocast state to a table, to handle cast to tensor
   local state = (type(state) == 'number') and {state} or state
   local obsv = torch.DoubleTensor(state):reshape(1,envDetails.nbStates)
   local out = agent.model:forward(obsv)
   local action
   -- Single discrete action space, action selection is based on the sampling of the, softmax probabilities output by the network
   -- Add small probability to prevent NaNs, could contain 0 -> log(0)= -inf -> theta = nans
   out:add(1e-6)
   if out:ne(out):sum() > 0 then
      print('Error in action selection')
      print(obsv, out, out:ne(out))
      print('Selecting a random action')
      action = client:env_action_space_sample(instance_id)
   else
      -- Sample action ~ p(s; θ)
      action = (torch.multinomial(out, 1)-1)[1][1]
   end
   return action
end
return selectAction