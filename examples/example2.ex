include ..\async_await.e as th
with trace

procedure main()
    
    Task t = async_proc( routine_id("task") )
    
    
    while 1 do
        puts(1, "For stop app, press key '1' in sequence of [ENTER]: ")
        sequence s = await_gets(0)
        if equal(s, "1") then
            
            return
        end if
    end while
    
end procedure

procedure task()
    
    while 1 do
        
        puts(1, "opa\n")
        task_yield()
        
    end while
    
end procedure

th:init(routine_id("main"))
system("pause")
