public class CityNodeCoord
{
    public String name;
    public double lat, lon;
    public int pop;
    public int originalIndex;

    CityNodeCoord(String name, double lat, double lon, int pop) // regular constructor
    {
        this.name = name;
        this.lat = lat;
        this.lon = lon;
        this.pop = pop;
    }

    CityNodeCoord(CityNodeCoord og) // deep copy constructor
    {
        this.name = og.name;
        this.lat = og.lat;
        this.lon = og.lon;
        this.pop = og.pop;
    }

    public static double getDistance(CityNodeCoord city1, CityNodeCoord city2)
    {
        return Math.sqrt(Math.pow(city1.lat - city2.lat, 2)
                       + Math.pow(city1.lon - city2.lon, 2));
    }
}
