include std\os.e
include std\task.e
include ..\async_await.e as th
include std\convert.e

global integer infinite_quit = 0

procedure main()
    Task p = async_proc( routine_id("task_infinite") )
    
    
    Task t2 = async( routine_id("task2") )
    
    puts(1, await( routine_id("task1") ))
    
    puts(1, await(t2))
    
    integer c = await_getc(0)
    
    if equal(c, '1') then
        infinite_quit = 1
    end if
    
end procedure

procedure task_infinite()

    integer i = 0
    while 1 do
        
        i += 1
        if infinite_quit then
            return
        end if
        puts(1, "task_infinite - "& to_string(i) &"\n")
        task_yield()
    end while
    
end procedure

function task1()
    
    for i = 1 to 5 do
        puts(1, "task1 - "& to_string(i) &"\n")
        task_delay(0.3)
    end for
    
    return "funcionou!! task1\n"
end function

function task2()
    
    for i = 1 to 5 do
        puts(1, "task2 - "& to_string(i) &"\n")
        task_delay(0.1)
    end for
    
    return "funcionou!! task2\n"
end function


th:init(routine_id("main"))
system("pause")

